using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120VehicleApproval
{
    public int VehicleAprId { get; set; }

    public int VehicleAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public int VehicleId { get; set; }

    public int ManufactureYear { get; set; }

    public double MaxLimit { get; set; }

    public double InitialEmpContribution { get; set; }

    public double VehicleCost { get; set; }

    public double EmployeeShare { get; set; }

    public string Attachment { get; set; } = null!;

    public string ApprovalStatus { get; set; } = null!;

    public DateTime ApprovalDate { get; set; }

    public double ApprovalAmount { get; set; }

    public decimal SEmpId { get; set; }

    public string Comments { get; set; } = null!;

    public int? TransactionBy { get; set; }

    public DateTime? TransactionDate { get; set; }

    public string VehicleModel { get; set; } = null!;

    public string VehicleManufacture { get; set; } = null!;

    public string? VehicleOption { get; set; }

    public virtual T0100VehicleApplication VehicleApp { get; set; } = null!;
}
