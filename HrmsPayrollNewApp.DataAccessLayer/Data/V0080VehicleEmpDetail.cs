using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0080VehicleEmpDetail
{
    public decimal CmpId { get; set; }

    public int VehicleId { get; set; }

    public string? VehicleType { get; set; }

    public decimal EmpId { get; set; }

    public double? MaxLimit { get; set; }

    public double? EmployeeContribution { get; set; }

    public int? NoOfYearLimit { get; set; }

    public bool? AttachMandatory { get; set; }

    public byte? VehicleAllowBeyondLimit { get; set; }

    public int EligibleJoiningMonths { get; set; }
}
