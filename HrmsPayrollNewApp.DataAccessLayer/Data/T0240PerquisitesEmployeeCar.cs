using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0240PerquisitesEmployeeCar
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal PerquisitesId { get; set; }

    public string FinancialYear { get; set; } = null!;

    public decimal UsageType { get; set; }

    public decimal OwnedType { get; set; }

    public decimal ActualExpencse { get; set; }

    public byte IsDepreciation { get; set; }

    public decimal CostOfCar { get; set; }

    public decimal CarHp { get; set; }

    public byte IsChauffeur { get; set; }

    public decimal ChauffeurSalary { get; set; }

    public decimal NoOfMonth { get; set; }

    public decimal AmountRecovered { get; set; }

    public decimal TotalPerqAmtPerMonth { get; set; }

    public decimal TotalPerqAmt { get; set; }

    public DateTime ChangeDate { get; set; }
}
