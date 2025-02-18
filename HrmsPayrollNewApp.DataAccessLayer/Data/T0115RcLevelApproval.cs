using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115RcLevelApproval
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? RcAppId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? RcId { get; set; }

    public DateTime? AprDate { get; set; }

    public decimal? AprAmount { get; set; }

    public decimal? TaxableExemptionAmount { get; set; }

    public string? AprComments { get; set; }

    public byte? AprStatus { get; set; }

    public decimal? RcAprEffectInSalary { get; set; }

    public string? RcAprChequeNo { get; set; }

    public string? PaymentMode { get; set; }

    public int CreateBy { get; set; }

    public DateTime DateCreated { get; set; }

    public int? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime? PaymentDate { get; set; }

    public byte RptLevel { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal ReimQuarId { get; set; }

    public string? QuarterName { get; set; }

    public virtual ICollection<T0115RcDependantDetailLevel> T0115RcDependantDetailLevels { get; set; } = new List<T0115RcDependantDetailLevel>();

    public virtual ICollection<T0115RcLtaTravelDetailLevel> T0115RcLtaTravelDetailLevels { get; set; } = new List<T0115RcLtaTravelDetailLevel>();

    public virtual ICollection<T0115RcReimbursementDetailLevel> T0115RcReimbursementDetailLevels { get; set; } = new List<T0115RcReimbursementDetailLevel>();
}
