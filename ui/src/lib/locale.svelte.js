let strings = $state({});
let currentLocale = $state('');

export function t(key) {
    return strings[key] ?? key;
}

export function getLocale() {
    return currentLocale;
}

export async function loadLocale(name) {
    const res = await fetch(`/api/v1/i18n/${encodeURIComponent(name)}`);
    if (!res.ok) return;
    const data = await res.json();
    for (const key of Object.keys(strings)) delete strings[key];
    Object.assign(strings, data);
    currentLocale = name;
}

export async function initLocale(override) {
    const res = await fetch('/api/v1/i18n');
    if (!res.ok) return [];
    const available = await res.json();
    const target = override && available.find(l => l.name === override)
        ? override
        : (() => {
            const lang = (navigator.language || 'en').split('-')[0].toLowerCase();
            return (available.find(l => l.code.toLowerCase() === lang)
                ?? available.find(l => l.name === 'English'))?.name ?? 'English';
        })();
    await loadLocale(target);
    return available;
}
