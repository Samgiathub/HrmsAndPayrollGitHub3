using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TblGeoAreaName
{
    public int Id { get; set; }

    public int CityId { get; set; }

    public string? AreaName { get; set; }

    public decimal? Latitude { get; set; }

    public decimal? Longitude { get; set; }
}
