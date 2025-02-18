using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0065EmpEmergencyContactDetailApp
{
    public long EmpTranId { get; set; }

    public int EmpApplicationId { get; set; }

    public int RowId { get; set; }

    public int CmpId { get; set; }

    public string Name { get; set; } = null!;

    public string RelationShip { get; set; } = null!;

    public string HomeTelNo { get; set; } = null!;

    public string HomeMobileNo { get; set; } = null!;

    public string WorkTelNo { get; set; } = null!;

    public int? ApprovedEmpId { get; set; }

    public DateTime? ApprovedDate { get; set; }

    public int? RptLevel { get; set; }

    public virtual T0060EmpMasterApp EmpTran { get; set; } = null!;
}
