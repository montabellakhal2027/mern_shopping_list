const mongoose = require('mongoose');
const { Schema, model } = mongoose;

// Create Schema
const ItemSchema = new Schema({
  name: {
    type: String,
    required: true
  },
  date: {
    type: Date,
    default: Date.now
  }
});

const Item = model('item', ItemSchema);

module.exports = Item;

