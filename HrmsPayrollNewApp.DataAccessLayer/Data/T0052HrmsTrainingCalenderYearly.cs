using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052HrmsTrainingCalenderYearly
{
    public decimal TrainingCalenderId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CalenderYear { get; set; }

    public decimal? CalenderMonth { get; set; }

    public decimal? TrainingId { get; set; }

    public string? BranchId { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0040HrmsTrainingMaster? Training { get; set; }
}
