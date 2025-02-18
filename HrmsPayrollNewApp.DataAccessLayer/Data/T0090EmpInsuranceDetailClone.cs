using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090EmpInsuranceDetailClone
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

    public DateTime SystemDate { get; set; }

    public decimal LoginId { get; set; }

    public decimal MonthlyPremium { get; set; }

    public string DeductFromSalary { get; set; } = null!;

    public DateTime? SalEffectiveDate { get; set; }
}
