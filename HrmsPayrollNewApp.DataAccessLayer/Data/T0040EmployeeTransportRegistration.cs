using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040EmployeeTransportRegistration
{
    public decimal TransportRegId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? RouteId { get; set; }

    public decimal? PickupId { get; set; }

    public decimal? VehicleId { get; set; }

    public decimal? DesignationId { get; set; }

    public int? TransportStatus { get; set; }

    public string? TransportType { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifiedBy { get; set; }

    public DateTime? ModifiedDate { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0040PickupStationMaster? Pickup { get; set; }

    public virtual T0040RouteMaster? Route { get; set; }

    public virtual T0040VehicleMaster? Vehicle { get; set; }
}
