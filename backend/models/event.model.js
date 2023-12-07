const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
  event_name: String,
  event_category: { type: String, required: true, default: "Pageants" },
  event_venue: String,
  event_organizer: String,
  event_date: Date,
  event_time: String,
  access_code: { type: String, required: true, unique: true },
  contestants: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Contestant' }],
  criteria: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Criteria' }],
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
});

eventSchema.statics.findEventByAccessCode = async function (accessCode) {
  return this.findOne({ access_code: accessCode });
};

const Event = mongoose.model('Event', eventSchema);

async function someFunction(eventId) {
  try {
    if (eventId === 'default') {
      const defaultEvent = new Event({
        _id: new mongoose.Types.ObjectId(), // Generate a new ObjectId
        access_code: { type: String, required: true },
        event_name: 'Default Event',
        event_category: 'Default Category',
        event_venue: 'Default Venue',
        event_organizer: 'Default Organizer',
        event_date: new Date(), // Default to the current date
        event_time: '12:00 PM', // Default time
        access_code: 'default_access_code',
        contestants: [], // Default to an empty array
        criteria: [],
        user: req.user && req.user._id, 
      });
      return defaultEvent;
    }

    let fetchedEvent;

    if (mongoose.Types.ObjectId.isValid(eventId)) {
      console.log('eventId:', eventId);
      const objectId = new mongoose.Types.ObjectId(eventId);
      fetchedEvent = await Event.findOne({ _id: objectId })
        .populate('contestants')
        .populate('criteria')
        .exec();
    } else {
      // If eventId is not a valid ObjectId, assume it's an access code
      fetchedEvent = await Event.findOne({ access_code: eventId })
        .populate('contestants')
        .populate('criteria')
        .exec();
    }

    if (!fetchedEvent) {
      console.error('Event not found');
      throw new Error('Event not found');
    }

    console.log('Populated Event:', fetchedEvent);
    return fetchedEvent;
  } catch (err) {
    console.error('Error finding event:', err);
    throw err;
  }
}


async function findEventByAccessCode(accessCode)  {
  try {
    if (accessCode === 'default') {
      const defaultEvent = new Event({
        _id: new mongoose.Types.ObjectId(), // Generate a new ObjectId
        event_name: 'Default Event',
        event_category: 'Default Category',
        event_venue: 'Default Venue',
        event_organizer: 'Default Organizer',
        event_date: new Date(), // Default to the current date
        event_time: '12:00 PM', // Default time
        access_code: 'default_access_code',
        contestants: [], // Default to an empty array
        criteria: [], 
        user: req.user && req.user._id, 
      });
      return defaultEvent;
    }
    const fetchedEvent = await Event.findOne({ access_code: accessCode })
      .populate('contestants')
      .populate('criteria') 
      .exec();

    if (!fetchedEvent) {
      console.error('Event not found');
      throw new Error('Event not found');
    }
    console.log('Populated Event:', fetchedEvent);
    return fetchedEvent;
  } catch (err) {
    console.error('Error finding event:', err);
    throw err; 
  }
}



module.exports = {
 someFunction,
 findEventByAccessCode,
  Event
};