using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100VehicleApplication
{
    public int VehicleAppId { get; set; }

    public decimal CmpId { get; set; }

    public int? VehicleId { get; set; }

    public string? VehicleType { get; set; }

    public decimal EmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public double MaxLimit { get; set; }

    public double InitialEmpContribution { get; set; }

    public double VehicleCost { get; set; }

    public double EmployeeShare { get; set; }

    public int? NoOfYearLimit { get; set; }

    public bool? AttachMandatory { get; set; }

    public byte? VehicleAllowBeyondLimit { get; set; }

    public string? AppStatus { get; set; }

    public DateTime? VehicleAppDate { get; set; }

    public string? Supervisor { get; set; }

    public decimal? EmpSuperior { get; set; }

    public string? DeptName { get; set; }

    public string? DesigName { get; set; }

    public string? BranchName { get; set; }

    public int? VehicleAprId { get; set; }

    public string? Attachment { get; set; }

    public int ManufactureYear { get; set; }

    public double? EmployeeContribution { get; set; }

    public string VehicleModel { get; set; } = null!;

    public string VehicleManufacture { get; set; } = null!;

    public string VehicleOption { get; set; } = null!;
}
