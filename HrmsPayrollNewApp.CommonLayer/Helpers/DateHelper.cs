namespace HrmsPayrollNewApp.CommonLayer.Helpers
{
    public static class DateHelper
    {
        /// <summary>
        /// Checks if the provided date falls on a weekend (Saturday or Sunday).
        /// </summary>
        /// <param name="date">The date to check.</param>
        /// <returns>True if the date is a weekend; otherwise, false.</returns>
        public static bool IsWeekend(DateTime date)
        {
            return date.DayOfWeek == DayOfWeek.Saturday || date.DayOfWeek == DayOfWeek.Sunday;
        }

        /// <summary>
        /// Calculates the number of days remaining until the next weekend from a given date.
        /// </summary>
        /// <param name="date">The starting date.</param>
        /// <returns>The number of days until the next Saturday.</returns>
        public static int DaysUntilWeekend(DateTime date)
        {
            int daysUntilSaturday = ((int)DayOfWeek.Saturday - (int)date.DayOfWeek + 7) % 7;
            return daysUntilSaturday;
        }
    }
}
