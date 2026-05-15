const supabase = require('../config/supabase');
const { isValidCategory, isValidCity } = require('../constants/options');

const editProfile = async (req, res) => {
    const attendee_id = req.user.id;
    const { name, phone_number, city, date_of_birth, gender } = req.body;

    if (!isValidCity(city)) {
        return res.status(400).json({ error: 'please select a valid city' });
    }

    const { data, error } = await supabase
        .from('Attendee')
        .update({
            name: name,
            phone_number: phone_number,
            city: city,
            date_of_birth: date_of_birth,
            gender: gender
        })
        .eq('attendee_id', attendee_id)
        .select()
        .single();

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.json({ message: 'profile updated', attendee: data });
};

const updateInterests = async (req, res) => {
    const attendee_id = req.user.id;
    const { interests } = req.body;

    if (!Array.isArray(interests) || interests.some((interest) => !isValidCategory(interest))) {
        return res.status(400).json({ error: 'please select valid interests' });
    }

    if (!interests || interests.length < 1) {
        return res.status(400).json({ error: 'you should select at least one interest' });
    }

    await supabase
        .from('Attendee_Interests')
        .delete()
        .eq('attendee_id', attendee_id);

    const newInterests = interests.map(interest => ({
        attendee_id: attendee_id,
        interests: interest
    }));

    const { data, error } = await supabase
        .from('Attendee_Interests')
        .insert(newInterests);

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.json({ message: 'interests updated' });
};

const likeEvent = async (req, res) => {
    const attendee_id = req.user.id;
    const { event_id } = req.body;

    const { data: existing } = await supabase
        .from('Interaction')
        .select('*')
        .eq('attendee_id', attendee_id)
        .eq('event_id', event_id)
        .eq('interaction_type', 'like')
        .maybeSingle();

    if (existing) {
        await supabase
            .from('Interaction')
            .delete()
            .eq('attendee_id', attendee_id)
            .eq('event_id', event_id)
            .eq('interaction_type', 'like');

        return res.json({ message: 'event unliked', liked: false });
    }

    const { error } = await supabase
        .from('Interaction')
        .insert([{
            attendee_id: attendee_id,
            event_id: event_id,
            interaction_type: 'like',
            interaction_value: 3
        }]);

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.json({ message: 'event liked', liked: true });
};

const getProfile = async (req, res) => {
    const attendee_id = req.user.id;

    const { data, error } = await supabase
        .from('Attendee')
        .select('name, phone_number, city, date_of_birth, gender, email')
        .eq('attendee_id', attendee_id)
        .single();

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    const { data: interestsData } = await supabase
        .from('Attendee_Interests')
        .select('interests')
        .eq('attendee_id', attendee_id);

    const interests = interestsData ? interestsData.map(i => i.interests) : [];

    res.json({ attendee: { ...data, interests: interests } });
};

const checkLike = async (req, res) => {
    const attendee_id = req.user.id;
    const { event_id } = req.params;

    const { data, error } = await supabase
        .from('Interaction')
        .select('*')
        .eq('attendee_id', attendee_id)
        .eq('event_id', event_id)
        .eq('interaction_type', 'like')
        .maybeSingle();

    if (error) {
        return res.json({ liked: false });
    }

    res.json({ liked: data ? true : false });
};

const logEventView = async (req, res) => {
    const attendee_id = req.user.id;
    const { event_id, duration_seconds } = req.body;
    const duration = Number(duration_seconds || 0);

    if (!event_id) {
        return res.status(400).json({ error: 'event_id is required' });
    }

    if (duration < 10) {
        return res.json({ message: 'view ignored because duration is below 10 seconds', recorded: false });
    }

    const { error } = await supabase
        .from('Interaction')
        .insert([{
            attendee_id,
            event_id,
            interaction_type: 'view',
            interaction_value: 1
        }]);

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.status(201).json({ message: 'event view recorded', recorded: true });
};

module.exports = { editProfile, updateInterests, likeEvent, getProfile, checkLike, logEventView };
