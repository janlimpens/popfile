export const connectivity = $state({
    offline: false,
    responseBody: null,
    nextRetryIn: 0,
});

let countdownTimer = null;
let retryDelay = 2;
let originalFetch = null;

function clearState() {
    connectivity.offline = false;
    connectivity.responseBody = null;
    connectivity.nextRetryIn = 0;
    retryDelay = 2;
    if (countdownTimer) { clearInterval(countdownTimer); countdownTimer = null; }
}

function scheduleRetry() {
    connectivity.nextRetryIn = retryDelay;
    retryDelay = Math.min(retryDelay * 2, 60);
    countdownTimer = setInterval(() => {
        connectivity.nextRetryIn = Math.max(0, connectivity.nextRetryIn - 1);
        if (connectivity.nextRetryIn === 0) {
            clearInterval(countdownTimer);
            countdownTimer = null;
            probe();
        }
    }, 1000);
}

function triggerOffline(body) {
    if (connectivity.offline) return;
    connectivity.offline = true;
    connectivity.responseBody = body;
    scheduleRetry();
}

async function probe() {
    try {
        const res = await originalFetch('/api/v1/config');
        if (res.status < 500) {
            clearState();
        } else {
            scheduleRetry();
        }
    } catch {
        scheduleRetry();
    }
}

export function reconnectNow() {
    if (countdownTimer) { clearInterval(countdownTimer); countdownTimer = null; }
    connectivity.nextRetryIn = 0;
    probe();
}

export function installFetchInterceptor() {
    originalFetch = window.fetch.bind(window);
    window.fetch = async (...args) => {
        try {
            const res = await originalFetch(...args);
            if (res.status >= 500) {
                const body = await res.clone().text().catch(() => null);
                triggerOffline(body);
                return res;
            }
            if (connectivity.offline) clearState();
            return res;
        } catch (err) {
            if (err instanceof TypeError) triggerOffline(null);
            throw err;
        }
    };
}
