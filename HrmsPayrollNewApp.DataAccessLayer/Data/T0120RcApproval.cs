using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120RcApproval
{
    public decimal RcAprId { get; set; }

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

    public byte DirectApproval { get; set; }

    public decimal ReimQuarId { get; set; }

    public string? QuarterName { get; set; }

    public virtual ICollection<T0210MonthlyReimDetail> T0210MonthlyReimDetails { get; set; } = new List<T0210MonthlyReimDetail>();
}
