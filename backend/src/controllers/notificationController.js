const supabase = require('../config/supabase');

// send notification to organizer
const sendNotification = async (organizer_id, message) => {
    const { error } = await supabase
        .from('Notification')
        .insert([{
            organizer_id: organizer_id,
            message: message
        }]);

    if (error) {
        console.log('notification error:', error.message);
    }
};

// get notifications for logged in organizer
const getNotifications = async (req, res) => {
    const organizer_id = req.user.id;

    const { data, error } = await supabase
        .from('Notification')
        .select('*')
        .eq('organizer_id', organizer_id)
        .order('created_at', { ascending: false });

    if (error) {
        return res.status(500).json({ error: error.message });
    }

    res.json({ notifications: data });
};

module.exports = { sendNotification, getNotifications };