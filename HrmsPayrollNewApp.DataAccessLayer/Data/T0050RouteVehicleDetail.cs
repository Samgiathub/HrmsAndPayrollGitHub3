using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050RouteVehicleDetail
{
    public decimal AssignId { get; set; }

    public decimal? VehicleId { get; set; }

    public decimal? RouteId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public virtual T0040RouteMaster? Route { get; set; }

    public virtual T0040VehicleMaster? Vehicle { get; set; }
}
