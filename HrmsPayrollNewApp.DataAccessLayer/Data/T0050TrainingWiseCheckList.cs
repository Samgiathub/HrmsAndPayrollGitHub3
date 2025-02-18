using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050TrainingWiseCheckList
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? TrainingId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public string? AssignCheckList { get; set; }

    public DateTime? ModifyDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public string? IpAddress { get; set; }
}
