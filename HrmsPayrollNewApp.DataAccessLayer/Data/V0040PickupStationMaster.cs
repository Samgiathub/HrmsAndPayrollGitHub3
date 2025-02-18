using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040PickupStationMaster
{
    public decimal PickupId { get; set; }

    public string? PickupName { get; set; }

    public decimal? RouteId { get; set; }

    public decimal? PickupKm { get; set; }

    public string? EffectiveDate { get; set; }

    public decimal? CmpId { get; set; }

    public string? RouteName { get; set; }
}
