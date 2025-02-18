using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100RcApplication
{
    public decimal RcAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal RcId { get; set; }

    public DateTime AppDate { get; set; }

    public decimal AppAmount { get; set; }

    public string? AppComments { get; set; }

    public byte AppStatus { get; set; }

    public DateTime? LeaveFromDate { get; set; }

    public DateTime? LeaveToDate { get; set; }

    public decimal? Days { get; set; }

    public string? Fy { get; set; }

    public byte? TaxException { get; set; }

    public string? FileName { get; set; }

    public decimal? RcAprId { get; set; }

    public byte? IsManagerRecord { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? TaxableAmount { get; set; }

    public byte SubmitFlag { get; set; }

    public decimal ReimQuarId { get; set; }

    public string? QuarterName { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0050AdMaster Rc { get; set; } = null!;

    public virtual ICollection<T0110RcDependantDetail> T0110RcDependantDetails { get; set; } = new List<T0110RcDependantDetail>();

    public virtual ICollection<T0110RcLtaTravelDetail> T0110RcLtaTravelDetails { get; set; } = new List<T0110RcLtaTravelDetail>();

    public virtual ICollection<T0110RcReimbursementDetail> T0110RcReimbursementDetails { get; set; } = new List<T0110RcReimbursementDetail>();
}
