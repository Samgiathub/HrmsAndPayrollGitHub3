using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TempWeeklyTimesheet
{
    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public DateOnly? WeekStartDate { get; set; }

    public DateOnly? WeekEndDate { get; set; }

    public DateOnly? MondayDate { get; set; }

    public DateOnly? TuesdayDate { get; set; }

    public DateOnly? WednesdayDate { get; set; }

    public DateOnly? ThursdayDate { get; set; }

    public DateOnly? FridayDate { get; set; }

    public DateOnly? SaturdayDate { get; set; }

    public DateOnly? SundayDate { get; set; }

    public decimal TimesheetId { get; set; }

    public decimal TimesheetDetailId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmployeeId { get; set; }

    public string? TimesheetPeriod { get; set; }

    public string? Mon { get; set; }

    public string? Tue { get; set; }

    public string? Wed { get; set; }

    public string? Thu { get; set; }

    public string? Fri { get; set; }

    public string? Sat { get; set; }

    public string? Sun { get; set; }

    public decimal? ProjectStatusId { get; set; }

    public string? MondayDes { get; set; }

    public string? TuesdayDes { get; set; }

    public string? WednesdayDes { get; set; }

    public string? ThursdayDes { get; set; }

    public string? FridayDes { get; set; }

    public string? SaturdayDes { get; set; }

    public string? SundayDes { get; set; }

    public string? Monday { get; set; }

    public string? Tuesday { get; set; }

    public string? Wednesday { get; set; }

    public string? Thursday { get; set; }

    public string? Friday { get; set; }

    public string? Saturday { get; set; }

    public string? Sunday { get; set; }

    public string? MondayDesc { get; set; }

    public string? TuesdayDesc { get; set; }

    public string? WednesdayDesc { get; set; }

    public string? ThursdayDesc { get; set; }

    public string? FridayDesc { get; set; }

    public string? SaturdayDesc { get; set; }

    public string? SundayDesc { get; set; }

    public DateTime? WeekStart { get; set; }

    public DateTime? WeekEnd { get; set; }
}
