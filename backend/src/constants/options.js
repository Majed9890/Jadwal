const CITY_OPTIONS = [
    'Riyadh',
    'Jeddah',
    'Mecca',
    'Medina',
    'Dammam',
    'Khobar',
    'Dhahran',
    'Taif',
    'Tabuk',
    'Abha',
    'Khamis Mushait',
    'Buraidah',
    'Hail',
    'Najran',
    'Jubail',
    'Yanbu',
    'Al Ahsa',
    'Arar',
    'Sakaka',
    'Jazan'
];

const CATEGORY_OPTIONS = [
    'Music',
    'Sports',
    'Art',
    'Technology',
    'Food',
    'Travel',
    'Fashion',
    'Gaming'
];

function isValidCity(city) {
    return CITY_OPTIONS.includes(city);
}

function isValidCategory(category) {
    return CATEGORY_OPTIONS.includes(category);
}

module.exports = {
    CITY_OPTIONS,
    CATEGORY_OPTIONS,
    isValidCity,
    isValidCategory
};
