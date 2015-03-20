/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

.pragma library

/*
  Extending Date with few prototypes
  */
Date.msPerDay = 86400e3
Date.msPerWeek = Date.msPerDay * 7

/*!
  The function returns a Date object with the current date and hour set to
  midnight.
  */
Date.prototype.midnight = function() {
    this.setHours(0, 0, 0, 0);
    return this;
}

/*!
  The function returns an invalid date object.
  Example of use:
  \code
  var invalidDate = Date.prototype.getInvalidDate.call();
  var otherInvalidDate = (new Date()).getInvalidDate();
  \endcode
  */
Date.prototype.getInvalidDate = function() {
    return new Date(-1, -1);
}

/*!
  The function checks whether the date object is a valid one, meaning the year,
  month and date fields are positive numbers
  */
Date.prototype.isValid = function() {
    if (Object.prototype.toString.call(this) !== "[object Date]") {
        return false;
    }
    return (this.getFullYear() > 0) && (this.getMonth() >= 0) && (this.getDate() > 0);
}

/*!
  The function returns the number of days in the month set in the Date object.
  */
Date.prototype.daysInMonth = function() {
    return [
        31/*an*/, 28/*Feb*/, 31/*Mar*/, 30/*Apr*/, 31/*May*/, 30/*Jun*/,
        31/*Jul*/, 31/*Aug*/, 30/*Sep*/, 31/*Oct*/, 30/*Nov*/, 31/*Dec*/
    ][this.getMonth()] + (this.getMonth() === 1) * this.leapYear();
}

/*!
  The function checks whether the year in the Date object is a leap year or not.
  */
Date.prototype.leapYear = function() {
    var year = this.getFullYear();
    return year % 400 == 0 || (year % 100 !== 0 && year % 4 == 0);
}

/*!
  The function returns the distance in months (not calendaristic months) between
  the Date object and the given one as parameter.
  */
Date.prototype.monthsTo = function(target) {
    return target.getMonth() - this.getMonth() + (12 * (target.getFullYear() - this.getFullYear()));
}

/*!
  Same as monthsTo, but returns the distance in days.
  */
Date.prototype.daysTo = function(target) {
    return !target.isValid() ? 0 : Math.ceil((target - this) / Date.msPerDay);
}

/*!
  Same as monthsTo, but returns the distance in hours.
  */
Date.prototype.hoursTo = function(target) {
    return !target.isValid() ? 0 : Math.ceil((target.getTime() - this.getTime()) / (1000 * 60 * 60));
}

/*!
  Same as monthsTo, but returns the distance in minutes.
  */
Date.prototype.minutesTo = function(target) {
    return !target.isValid() ? 0 : Math.ceil((target.getTime() - this.getTime()) / (1000 * 60));
}

/*!
  Same as monthsTo, but returns the distance in seconds.
  */
Date.prototype.secondsTo = function(target) {
    return !target.isValid() ? 0 : Math.ceil((target.getTime() - this.getTime()) / 1000);
}

/*!
  The function returns the week number of the date stored in the object.
  */
Date.prototype.getWeek = function() {
    // Copy date so don't modify original
    var date = new Date(this);
    date.setHours(0, 0, 0, 0);
    // Set to nearest Thursday: current date + 4 - current day number
    // Make Sunday's day number 7
    date.setDate(date.getDate() + 4 - (date.getDay() || 7));
    // Get first day of year
    var yearStart = new Date(date.getFullYear(), 0, 1);
    // Calculate full weeks to nearest Thursday
    var weekNo = Math.ceil((((date - yearStart) / 86400000) + 1) / 7);
    // Return array of year and week number
    return weekNo;
}
