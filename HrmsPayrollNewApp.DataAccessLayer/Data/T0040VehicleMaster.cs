using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040VehicleMaster
{
    public decimal VehicleId { get; set; }

    public string? VehicleName { get; set; }

    public string? VehicleNo { get; set; }

    public string? VehicleType { get; set; }

    public string? VehicleOwner { get; set; }

    public string? OwnerName { get; set; }

    public string? OwnerContactNo { get; set; }

    public string? DriverName { get; set; }

    public string? DriverContactNo { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public virtual ICollection<T0040EmployeeTransportRegistration> T0040EmployeeTransportRegistrations { get; set; } = new List<T0040EmployeeTransportRegistration>();

    public virtual ICollection<T0050RouteVehicleDetail> T0050RouteVehicleDetails { get; set; } = new List<T0050RouteVehicleDetail>();
}
