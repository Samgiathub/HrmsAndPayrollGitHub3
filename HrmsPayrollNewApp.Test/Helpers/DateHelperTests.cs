using HrmsPayrollNewApp.CommonLayer.Helpers;
using Microsoft.Extensions.Configuration.UserSecrets;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HrmsPayrollNewApp.Test.Helpers
{
    public class DateHelperTests
    {
        [Fact]
        public void IsWeekend_ReturnsTrue_ForSaturday()
        {
            // Arrange
            var saturday = new DateTime(2024, 11, 16);

            // Act
            var result = DateHelper.IsWeekend(saturday);

            // Assert
            Assert.True(result);
        }

        [Fact]
        public void IsWeekend_ReturnsTrue_ForSunday()
        {
            // Arrange
            var sunday = new DateTime(2024, 11, 17);

            // Act
            var result = DateHelper.IsWeekend(sunday);

            // Assert
            Assert.True(result);
        }

        [Fact]
        public void IsWeekend_ReturnsFalse_ForWeekday()
        {
            // Arrange
            var monday = new DateTime(2024, 11, 18);

            // Act
            var result = DateHelper.IsWeekend(monday);

            // Assert
            Assert.False(result);
        }
    }
}
