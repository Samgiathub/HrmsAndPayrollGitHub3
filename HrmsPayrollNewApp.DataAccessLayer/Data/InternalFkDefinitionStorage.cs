using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class InternalFkDefinitionStorage
{
    public int Id { get; set; }

    public string FkName { get; set; } = null!;

    public string FkCreationStatement { get; set; } = null!;

    public string FkDestructionStatement { get; set; } = null!;

    public string TableTruncationStatement { get; set; } = null!;
}
