const express = require('express');
const app = express();
const port = process.env.PORT || 8080;
const cors = require('cors');
const bodyParser = require('body-parser');
const mongoose = require('mongoose');
const passport = require('passport');
const session = require('express-session'); // Add this line
const passportConfig = require('./passport-config');

//const verifyToken = require('event.route');
mongoose.set('strictPopulate', false);

mongoose.connect("mongodb://127.0.0.1:27017/tabdb")
  .then(() => {
    console.log('MongoDB connected successfully');
    app.listen(port, () => {
      console.log('Running and connected on port ' + port);
    });
  })
  .catch((err) => {
    console.error('Error connecting to MongoDB:', err);
  });

app.use(cors());
app.use(express.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use('/uploads', express.static('uploads'));

const corsOptions = {
  origin: 'http://127.0.0.1:8080',
  methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
  credentials: true,
};

app.use(cors(corsOptions));
app.use(session({ secret: 'your-secret-key', resave: true, saveUninitialized: true }));
app.use(passportConfig.passport.initialize());
app.use(passport.session());

const verifyToken = require('./routes/event.route');
app.use(verifyToken);
app.use('/', require('./routes/user.route'));
app.use('/', require('./routes/event.route'));
app.use('/', require('./routes/contestant.route'));
app.use('/', require('./routes/criteria.route'));
app.use('/api', require('./routes/event.route'));
