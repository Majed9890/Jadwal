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

    // delete old interests first
    await supabase
        .from('Attendee_Interests')
        .delete()
        .eq('attendee_id', attendee_id);

    // add new interests
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

// like event
const likeEvent = async (req, res) => {
    const attendee_id = req.user.id;
    const { event_id } = req.body;

    const { data, error } = await supabase
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

    res.json({ message: 'event liked' });
};

module.exports = { editProfile, updateInterests, likeEvent };