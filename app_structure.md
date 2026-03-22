flowchart TD
    A[App] --> B[Home Page]
    A --> C[List Page]
    A --> D[Setting Page]
    A --> ADD[Bottom Right Plus Button]

    %% Home Page
    B --> B2[AI Analysis Section]
    B --> B3[Recently Added Section]

    %% Add Flow
    ADD[Bottom Right Plus Button] --> E{Drink Type Selection Menu}
    E -->|Wine| F[Add Drink Page]
    E -->|Beer| F
    E -->|Cocktail| F

    %% Add Drink Page Fields
    F --> F1[Name]
    F --> F2[Scan Barcode]
    F --> F3[Sweetness Slider]
    F --> F4[Bitterness Slider]
    F --> F5[Image Selection]
    F --> F6[Category / Detailed Type]
    F --> F7[Notes Section]
    F --> F8[Drink Rating]
    F --> F9[Purchase Date]
    F --> F10[Origin]
    F --> F11[Save Drink]

    %% Database
    F11 -->|Save to DB| Database@{ shape: cyl, label: "Database" }

    %% Drink Detail Navigation
    Database -->|Open Detail| I[Drink Detail Page]

    %% Edit Flow from Detail Page
    I edit@--> I1[Edit Drink Page]
    I1 edit2@--> I2[Done / Update Drink]
    I2 edit3@-->|**Update DB**| Database
    edit@{ animate: true }
    edit2@{ animate: true }
    edit3@{ animate: true }
    %% Delete Flow from Detail Page
    I delete@==> I3[Trash Button]
    I3 delete2@==> I4{Confirm Delete?}
    I4 -->|No| I
    I4 delete3@==>|Yes| I5[Delete Drink]
    I5 delete4@==>|Delete from DB| Database
    Database delete5@==>|Pop Navigation Stack| I6[Return to Previous Page]
    delete@{ animate: true, animation: slow }
    delete2@{ animate: true, animation: slow }
    delete3@{ animate: true, animation: slow }
    delete4@{ animate: true, animation: slow }
    delete5@{ animate: true, animation: slow }
    %% AI Section
    B2 -->|Beer Tab| G[Analyze Result Wine/Beer/Cocktail]
    B2 -->|Wine Tab| G
    B2 -->|Cocktail Tab| G
    G --> G1[Preference Insights]
    G --> G2[Taste Pattern Analysis]
    G --> G3[Recommendation Suggestions]

    %% Recently Added
    B3 --> H[Recent Drink Cards]
    H -->|Tap Drink Card| I

    %% List Page
    C --> C1[All Drinks List]
    C --> C2[Filter Button]
    C --> C3[Search Section]

    C1 -->|Tap Drink Row| I

    C2 --> C21[Filter by Type]
    C2 --> C22[Filter by Rating]
    C2 --> C23[Filter by Date]
    C2 --> C24[Filter by Origin]

    C3 --> C31[Search by Drink Name]

    %% Settings Page
    D --> D4[Data / Privacy Settings]
    D --> D5[About / Help]

    %% Node Styling Rules
    classDef choiceNode fill:#FFF3BF,stroke:#E0A800,stroke-width:2px,color:#5C4400;
    classDef databaseNode fill:#D9F2E6,stroke:#198754,stroke-width:3px,color:#0F5132;

    %% Process Styling Rules
    classDef editFlow stroke:#3B82F6,stroke-width:3px,color:#3B82F6,animate:true;
    classDef deleteFlow stroke:#EF4444,stroke-width:3px,color:#EF4444,stroke-dasharray:6\,4,animate:true;

    %% Apply Node Styling
    class E,I4 choiceNode;
    class Database databaseNode;

    %% Apply Process Styling
    class edit,edit2,edit3 editFlow;
    class delete,delete2,delete3,delete4,delete5 deleteFlow;
