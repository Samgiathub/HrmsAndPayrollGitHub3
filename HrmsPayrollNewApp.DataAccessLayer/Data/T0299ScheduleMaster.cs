using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0299ScheduleMaster
{
    public decimal SchId { get; set; }

    public string SchName { get; set; } = null!;

    public string ReminderName { get; set; } = null!;

    public string SchType { get; set; } = null!;

    public decimal DateRun { get; set; }

    public string? DateWeekly { get; set; }

    public string? SchTime { get; set; }

    public string? CcEmailId { get; set; }

    public DateTime? ModifyDate { get; set; }

    public decimal CmpId { get; set; }

    public decimal? SchHours { get; set; }

    public byte? IsTime { get; set; }

    public string? Parameter { get; set; }

    public string? LeaveIds { get; set; }
}
