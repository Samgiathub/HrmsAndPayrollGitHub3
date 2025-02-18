using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050AdExpenseLimitMaster
{
    public decimal AdExpMasterId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AdId { get; set; }

    public string AdExpName { get; set; } = null!;

    public string MaxLimitType { get; set; } = null!;

    public decimal? FixedMaxLimit { get; set; }

    public DateTime? StDateYear { get; set; }

    public int? NoOfYear { get; set; }

    public DateTime CreatedDate { get; set; }

    public decimal CreatedBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public decimal ItRowNo { get; set; }

    public virtual T0050AdMaster Ad { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0050AdExpenseLimit> T0050AdExpenseLimits { get; set; } = new List<T0050AdExpenseLimit>();

    public virtual ICollection<T0110RcDependantDetail> T0110RcDependantDetails { get; set; } = new List<T0110RcDependantDetail>();

    public virtual ICollection<T0110RcLtaTravelDetail> T0110RcLtaTravelDetails { get; set; } = new List<T0110RcLtaTravelDetail>();

    public virtual ICollection<T0110RcReimbursementDetail> T0110RcReimbursementDetails { get; set; } = new List<T0110RcReimbursementDetail>();

    public virtual ICollection<T0115RcDependantDetailLevel> T0115RcDependantDetailLevels { get; set; } = new List<T0115RcDependantDetailLevel>();

    public virtual ICollection<T0115RcLtaTravelDetailLevel> T0115RcLtaTravelDetailLevels { get; set; } = new List<T0115RcLtaTravelDetailLevel>();

    public virtual ICollection<T0115RcReimbursementDetailLevel> T0115RcReimbursementDetailLevels { get; set; } = new List<T0115RcReimbursementDetailLevel>();
}
