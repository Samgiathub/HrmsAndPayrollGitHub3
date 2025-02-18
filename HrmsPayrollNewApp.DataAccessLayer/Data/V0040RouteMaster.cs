using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040RouteMaster
{
    public decimal RouteId { get; set; }

    public string? RouteName { get; set; }

    public string? RouteNo { get; set; }

    public decimal? RouteKm { get; set; }

    public string? FuelPlace { get; set; }

    public decimal? VehicleId { get; set; }

    public string? EffectiveDate { get; set; }

    public decimal? CmpId { get; set; }
}
