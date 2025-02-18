using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0052HrmsTrainingCalenderYearly
{
    public decimal TrainingCalenderId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CalenderYear { get; set; }

    public decimal? CalenderMonth { get; set; }

    public decimal? TrainingId { get; set; }

    public string? TrainingName { get; set; }

    public string? MonthName { get; set; }

    public string? BranchName { get; set; }
}
