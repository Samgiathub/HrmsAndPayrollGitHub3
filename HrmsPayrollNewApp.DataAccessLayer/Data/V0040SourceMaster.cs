using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040SourceMaster
{
    public decimal SourceId { get; set; }

    public string SourceName { get; set; } = null!;

    public decimal SourceTypeId { get; set; }

    public string? Comments { get; set; }

    public string SourceTypeName { get; set; } = null!;
}
