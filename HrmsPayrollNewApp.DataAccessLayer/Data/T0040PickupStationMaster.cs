using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040PickupStationMaster
{
    public decimal PickupId { get; set; }

    public string? PickupName { get; set; }

    public decimal? RouteId { get; set; }

    public decimal? PickupKm { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifiedBy { get; set; }

    public DateTime? ModifiedDate { get; set; }

    public virtual T0040RouteMaster? Route { get; set; }

    public virtual ICollection<T0040EmployeeTransportRegistration> T0040EmployeeTransportRegistrations { get; set; } = new List<T0040EmployeeTransportRegistration>();

    public virtual ICollection<T0040PickupStationFareMaster> T0040PickupStationFareMasters { get; set; } = new List<T0040PickupStationFareMaster>();
}
