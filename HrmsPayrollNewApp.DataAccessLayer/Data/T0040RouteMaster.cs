using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040RouteMaster
{
    public decimal RouteId { get; set; }

    public string? RouteName { get; set; }

    public string? RouteNo { get; set; }

    public decimal? RouteKm { get; set; }

    public string? FuelPlace { get; set; }

    public decimal? VehicleId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifiedBy { get; set; }

    public DateTime? ModifiedDate { get; set; }

    public virtual ICollection<T0040EmployeeTransportRegistration> T0040EmployeeTransportRegistrations { get; set; } = new List<T0040EmployeeTransportRegistration>();

    public virtual ICollection<T0040PickupStationMaster> T0040PickupStationMasters { get; set; } = new List<T0040PickupStationMaster>();

    public virtual ICollection<T0050RouteVehicleDetail> T0050RouteVehicleDetails { get; set; } = new List<T0050RouteVehicleDetail>();
}
