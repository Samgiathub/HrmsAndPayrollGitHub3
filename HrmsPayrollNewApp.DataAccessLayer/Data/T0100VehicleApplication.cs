using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100VehicleApplication
{
    public int VehicleAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public int VehicleId { get; set; }

    public int ManufactureYear { get; set; }

    public double MaxLimit { get; set; }

    public double InitialEmpContribution { get; set; }

    public double VehicleCost { get; set; }

    public double EmployeeShare { get; set; }

    public string? Attachment { get; set; }

    public string AppStatus { get; set; } = null!;

    public DateTime? VehicleAppDate { get; set; }

    public int? TransactionBy { get; set; }

    public DateTime? TransactionDate { get; set; }

    public string VehicleModel { get; set; } = null!;

    public string VehicleManufacture { get; set; } = null!;

    public string? VehicleOption { get; set; }

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0110VehicleRegistrationDetail> T0110VehicleRegistrationDetails { get; set; } = new List<T0110VehicleRegistrationDetail>();

    public virtual ICollection<T0120VehicleApproval> T0120VehicleApprovals { get; set; } = new List<T0120VehicleApproval>();

    public virtual T0040VehicleTypeMaster Vehicle { get; set; } = null!;
}
