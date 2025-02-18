using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class GetTimesheetDetailsApproval
{
    public decimal? TimesheetId { get; set; }

    public decimal? ProjectId { get; set; }

    public decimal? TaskId { get; set; }

    public decimal? ClientId { get; set; }

    public string? ClientName { get; set; }

    public string? ProjectCode { get; set; }

    public string? Monday { get; set; }

    public string? MondayDes { get; set; }

    public string? Tuesday { get; set; }

    public string? TuesdayDes { get; set; }

    public string? Wednesday { get; set; }

    public string? WednesdayDes { get; set; }

    public string? Thursday { get; set; }

    public string? ThursdayDes { get; set; }

    public string? Friday { get; set; }

    public string? FridayDes { get; set; }

    public string? Saturday { get; set; }

    public string? SaturdayDes { get; set; }

    public string? Sunday { get; set; }

    public string? SundayDes { get; set; }

    public string? ProjectName { get; set; }

    public string? TaskName { get; set; }

    public decimal? CmpId { get; set; }

    public string? TimesheetPeriod { get; set; }

    public decimal? ProjectStatusId { get; set; }

    public string? ProjectStatus { get; set; }

    public string? Description { get; set; }

    public string? Tscolor { get; set; }

    public string? Attachment { get; set; }
}
