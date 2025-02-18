using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120HrmsTrainingSchedule
{
    public decimal ScheduleId { get; set; }

    public decimal? TrainingAppId { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? FromTime { get; set; }

    public string? ToTime { get; set; }

    public decimal? CmpId { get; set; }
}
