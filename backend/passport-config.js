const JwtStrategy = require('passport-jwt').Strategy;
const ExtractJwt = require('passport-jwt').ExtractJwt;
const LocalStrategy = require('passport-local').Strategy;
const config = require('./config/config');
const axios = require('axios');
const User = require('./models/user.model');
const passport = require('passport');



const opts = {
  jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
  //opts.secretOrKey = 'your-secret-key';  // Replace with your actual secret key
  secretOrKey: config.secretOrKey,


};


passport.serializeUser((user, done) => {
    done(null, user.id);
  });
  
  passport.deserializeUser((id, done) => {
    User.findById(id, (err, user) => {
      done(err, user);
    });
  });
  
passport.use(new JwtStrategy(opts, (jwt_payload, done) => {
  console.log('Passport JWT Strategy Callback - jwt_payload:', jwt_payload);
  User.findById(jwt_payload.id, (err, user) => {
    if (err) {
      console.error('Passport JWT Strategy Callback - Error:', err);
      return done(err, false);
    }
    if (user) {
      console.log('Passport JWT Strategy Callback - User found:', user);
      return done(null, user);
    } else {
      console.log('Passport JWT Strategy Callback - User not found');
      return done(null, false);
      // You might want to create a new account or handle this case differently
    }
  });
}));

passport.use(new LocalStrategy(
  { usernameField: 'email' }, // Adjust based on your user model
  async (email, password, done) => {
    try {
      const user = await User.findOne({ email });

      if (!user || !user.comparePassword(password)) {
        return done(null, false, { message: 'Invalid credentials' });
      }

      return done(null, user);
    } catch (error) {
      return done(error);
    }
  }
));
// Example using Axios
const token = 'your-authentication-token'; // Replace with the actual token

axios.get('http://127.0.0.1:8080/api/events', { headers: { 
  Authorization: `Bearer ${token}` } })
  .then(response => {
    console.log(response.data);
  })
  .catch(error => {
    if (error.response) {
      // The request was made and the server responded with a status code
      console.error('Response error:', error.response.status, error.response.data);
    } else if (error.request) {
      // The request was made but no response was received
      console.error('No response received:', error.request);
    } else {
      // Something happened in setting up the request that triggered an Error
      console.error('Error setting up the request:', error.message);
    }
  });
 
  
  // JWT strategy for token authentication
  passport.use(new JwtStrategy(
    {
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: 'your-secret-key', // Replace with your secret key
    },
    async (jwtPayload, done) => {
      try {
        const user = await User.findById(jwtPayload.sub);
  
        if (!user) {
          return done(null, false);
        }
  
        return done(null, user);
      } catch (error) {
        return done(error);
      }
    }
  ));
  
  const jwtStrategy = new JwtStrategy(opts, async (jwt_payload, done) => {
    try {
      const user = await User.findById(jwt_payload.id);
  
      if (!user) {
        return done(null, false);
      }
  
      return done(null, user);
    } catch (error) {
      return done(error, false);
    }
  });
  
// Export the passport instance and jwtStrategy
module.exports = {
  passport,
  jwtStrategy
  }

