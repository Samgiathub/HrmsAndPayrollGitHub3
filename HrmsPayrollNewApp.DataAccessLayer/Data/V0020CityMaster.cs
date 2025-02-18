using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0020CityMaster
{
    public decimal CityId { get; set; }

    public string? CityName { get; set; }

    public decimal StateId { get; set; }

    public string StateName { get; set; } = null!;

    public string? LocName { get; set; }

    public decimal? LocId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal CityCatId { get; set; }

    public string CityCatName { get; set; } = null!;
}
