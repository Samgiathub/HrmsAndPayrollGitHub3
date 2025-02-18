using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040OtHrsCnv
{
    public int Noid { get; set; }

    public DateTime EffectiveDate { get; set; }

    public decimal? ActualHrs { get; set; }

    public decimal? BelowHrs { get; set; }

    public decimal? AboveHrs { get; set; }

    public decimal? Limit { get; set; }

    public int? CmpId { get; set; }
}
