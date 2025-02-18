using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0060ExtraIncrementUtility
{
    public decimal ExtraIncrementUtilityId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public byte EligibleType { get; set; }

    public int ResId { get; set; }

    public decimal EmpId { get; set; }

    public decimal Amount { get; set; }

    public DateTime? AppraisalFrom { get; set; }

    public DateTime? AppraisalTo { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040ReasonMaster Res { get; set; } = null!;
}
