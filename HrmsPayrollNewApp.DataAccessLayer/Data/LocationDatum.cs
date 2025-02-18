using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class LocationDatum
{
    public int Id { get; set; }

    public double? Latitude { get; set; }

    public double? Longitude { get; set; }

    public DateTime? Date { get; set; }
}
