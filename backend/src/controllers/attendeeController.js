const supabase = require('../config/supabase');

// edit profile
const editProfile = async (req, res) => {
    const attendee_id = req.user.id;
    const { name, phone_number, city, date_of_birth, gender } = req.body;

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

// update interests
const updateInterests = async (req, res) => {
    const attendee_id = req.user.id;
    const { interests } = req.body;

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

// like or unlike event
const likeEvent = async (req, res) => {
    const attendee_id = req.user.id;
    const { event_id } = req.body;

    const { data: existing } = await supabase
        .from('Interaction')
        .select('*')
        .eq('attendee_id', attendee_id)
        .eq('event_id', event_id)
        .eq('interaction_type', 'like')
        .single();

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

// get attendee profile
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

// check if attendee liked an event
const checkLike = async (req, res) => {
    const attendee_id = req.user.id;
    const { event_id } = req.params;

    const { data, error } = await supabase
        .from('Interaction')
        .select('*')
        .eq('attendee_id', attendee_id)
        .eq('event_id', event_id)
        .eq('interaction_type', 'like')
        .single();

    if (error) {
        return res.json({ liked: false });
    }

    res.json({ liked: data ? true : false });
};

module.exports = { editProfile, updateInterests, likeEvent, getProfile, checkLike };