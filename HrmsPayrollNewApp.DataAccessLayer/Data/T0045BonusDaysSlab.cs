using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0045BonusDaysSlab
{
    public int RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }

    public decimal FromDays { get; set; }

    public decimal ToDays { get; set; }

    public decimal Percentage { get; set; }

    public virtual T0040BonusCalc Tran { get; set; } = null!;
}
