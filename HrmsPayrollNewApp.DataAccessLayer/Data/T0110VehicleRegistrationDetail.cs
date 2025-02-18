using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110VehicleRegistrationDetail
{
    public int VehicleRegistrationId { get; set; }

    public int VehicleAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public int VehicleId { get; set; }

    public string EngineNo { get; set; } = null!;

    public string ChasisNo { get; set; } = null!;

    public double RoadTax { get; set; }

    public double RegistrationCharges { get; set; }

    public double InsuranceCharges { get; set; }

    public string InvoiceNo { get; set; } = null!;

    public double? InvoiceAmount { get; set; }

    public string VehicleDocs { get; set; } = null!;

    public int TransactionBy { get; set; }

    public DateTime TransactionDate { get; set; }

    public DateTime? InvoiceDate { get; set; }

    public string? PaymentAckDetails { get; set; }

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040VehicleTypeMaster Vehicle { get; set; } = null!;

    public virtual T0100VehicleApplication VehicleApp { get; set; } = null!;
}
