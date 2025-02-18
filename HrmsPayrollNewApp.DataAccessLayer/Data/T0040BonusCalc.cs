using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040BonusCalc
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal BranchId { get; set; }

    public string Particulars { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal BonusCalculateOn { get; set; }

    public virtual ICollection<T0045BonusDaysSlab> T0045BonusDaysSlabs { get; set; } = new List<T0045BonusDaysSlab>();
}
