using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120LtaMedicalApproval
{
    public decimal LmAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LmAppId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime? AprDate { get; set; }

    public string? AprCode { get; set; }

    public decimal? AprAmount { get; set; }

    public string? AprComments { get; set; }

    public DateTime? SystemDate { get; set; }

    public int? AprStatus { get; set; }

    public int? TypeId { get; set; }

    public decimal? LoginId { get; set; }

    public int? EffectSalary { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0110LtaMedicalApplication LmApp { get; set; } = null!;

    public virtual ICollection<T0130LtaForDependant> T0130LtaForDependants { get; set; } = new List<T0130LtaForDependant>();

    public virtual ICollection<T0130LtaJurneyDetail> T0130LtaJurneyDetails { get; set; } = new List<T0130LtaJurneyDetail>();

    public virtual ICollection<T0210LtaMedicalPayment> T0210LtaMedicalPayments { get; set; } = new List<T0210LtaMedicalPayment>();
}
