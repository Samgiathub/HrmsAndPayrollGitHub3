using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050SubVertical
{
    public decimal SubVerticalId { get; set; }

    public string? VerticalName { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? VerticalId { get; set; }

    public string? SubVerticalCode { get; set; }

    public string? SubVerticalName { get; set; }

    public string? SubVerticalDescription { get; set; }

    public byte? IsActive { get; set; }
}
