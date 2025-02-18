using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpInsuranceDetail
{
    public decimal EmpInsTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal InsTranId { get; set; }

    public string InsCmpName { get; set; } = null!;

    public string InsPolicyNo { get; set; } = null!;

    public DateTime? InsTakenDate { get; set; }

    public DateTime? InsDueDate { get; set; }

    public DateTime? InsExpDate { get; set; }

    public decimal InsAmount { get; set; }

    public decimal InsAnualAmt { get; set; }

    public decimal LoginId { get; set; }

    public decimal MonthlyPremium { get; set; }

    public byte DeductFromSalary { get; set; }

    public DateTime? SalEffectiveDate { get; set; }

    public string? EmpDependentId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040InsuranceMaster InsTran { get; set; } = null!;
}
