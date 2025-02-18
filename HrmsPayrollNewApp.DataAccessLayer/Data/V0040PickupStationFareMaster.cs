using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040PickupStationFareMaster
{
    public decimal FareId { get; set; }

    public decimal? PickupId { get; set; }

    public decimal? Fare { get; set; }

    public decimal? Discount { get; set; }

    public decimal? NetFare { get; set; }

    public string? EffectiveDate { get; set; }

    public decimal? CmpId { get; set; }

    public string? PickupName { get; set; }

    public decimal? RouteId { get; set; }

    public string? RouteName { get; set; }

    public string? RouteNo { get; set; }

    public decimal? RouteKm { get; set; }

    public decimal? PickupKm { get; set; }
}
