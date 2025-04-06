import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';

class AgricultureScreen extends StatefulWidget {
  const AgricultureScreen({super.key});

  @override
  State<AgricultureScreen> createState() => _AgricultureScreenState();
}

class _AgricultureScreenState extends State<AgricultureScreen> {
  final _aiService = AIService();
  bool _isLoading = false;
  String? _error;
  String? _weatherInfo;
  String? _cropInfo;
  String? _fertilizerInfo;
  final _localityController = TextEditingController();
  bool _showResults = false;

  // Location selection
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;
  String? _selectedLocality;

  // Dynamic farming options
  List<String> _farmingTypes = [];
  String? _selectedFarmingType;

  // Dynamic season options
  List<String> _seasons = [];
  String? _selectedSeason;

  // Dynamic location data
  Map<String, Map<String, List<String>>> _locationData = {};
  List<String> _countries = [];

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      const prompt = '''
      Please provide a list of countries that are significant for agriculture.
      Format the response as a JSON object with the following structure:
      {
        "countries": ["Country1", "Country2", "Country3", ...]
      }
      Include only the most agriculturally significant countries, focusing on:
      1. Major agricultural producers
      2. Countries with diverse farming practices
      3. Nations with significant agricultural exports
      4. Countries with unique agricultural challenges
      ''';

      final response = await _aiService.getAIResponse(prompt);
      final countries = _parseJsonResponse(response);
      
      setState(() {
        _countries = countries;
        for (var country in countries) {
          _locationData[country] = {};
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch countries. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchStatesForCountry(String country) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prompt = '''
      Please provide a list of states/regions in $country that are significant for agriculture.
      Format the response as a JSON object with the following structure:
      {
        "states": ["State1", "State2", "State3", ...]
      }
      Include only the most agriculturally significant states, considering:
      1. Major crop-producing regions
      2. Areas with diverse farming practices
      3. Regions with unique agricultural challenges
      4. States with significant agricultural infrastructure
      ''';

      final response = await _aiService.getAIResponse(prompt);
      final states = _parseJsonResponse(response);
      
      setState(() {
        _locationData[country] = {};
        for (var state in states) {
          _locationData[country]![state] = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch states. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCitiesForState(String country, String state) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prompt = '''
      Please provide a list of major cities in $state, $country that are significant for agriculture.
      Format the response as a JSON object with the following structure:
      {
        "cities": ["City1", "City2", "City3", ...]
      }
      Include only the most agriculturally significant cities, considering:
      1. Cities with major agricultural markets
      2. Areas with significant farming communities
      3. Locations with agricultural research centers
      4. Cities with agricultural processing facilities
      ''';

      final response = await _aiService.getAIResponse(prompt);
      final cities = _parseJsonResponse(response);
      
      setState(() {
        _locationData[country]![state] = cities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch cities. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFarmingTypes() async {
    if (_selectedCountry == null || _selectedState == null || _selectedCity == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prompt = '''
      For $_selectedCity, $_selectedState, $_selectedCountry, please provide a list of suitable farming types.
      Format the response as a JSON object with the following structure:
      {
        "farming_types": ["Type1", "Type2", "Type3", ...]
      }
      Consider:
      1. Local climate and weather conditions
      2. Available resources and infrastructure
      3. Traditional farming practices in the region
      4. Market demand and economic viability
      5. Environmental sustainability
      ''';

      final response = await _aiService.getAIResponse(prompt);
      final farmingTypes = _parseJsonResponse(response);
      
      setState(() {
        _farmingTypes = farmingTypes;
        _selectedFarmingType = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch farming types. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSeasons() async {
    if (_selectedCountry == null || _selectedState == null || _selectedCity == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prompt = '''
      For $_selectedCity, $_selectedState, $_selectedCountry, please provide a list of relevant agricultural seasons.
      Format the response as a JSON object with the following structure:
      {
        "seasons": ["Season1", "Season2", "Season3", ...]
      }
      Consider:
      1. Local climate patterns
      2. Traditional growing seasons
      3. Regional weather variations
      4. Crop-specific seasons
      5. Cultural or regional seasonal terms
      ''';

      final response = await _aiService.getAIResponse(prompt);
      final seasons = _parseJsonResponse(response);
      
      setState(() {
        _seasons = seasons;
        _selectedSeason = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch seasons. Please try again.';
        _isLoading = false;
      });
    }
  }

  List<String> _parseJsonResponse(String response) {
    try {
      // Extract the array from the JSON response
      final startIndex = response.indexOf('[');
      final endIndex = response.lastIndexOf(']');
      if (startIndex != -1 && endIndex != -1) {
        final arrayStr = response.substring(startIndex, endIndex + 1);
        return arrayStr
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll('"', '')
            .split(',')
            .map((e) => e.trim())
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> _getAgricultureInfo() async {
    if (_selectedCountry == null ||
        _selectedState == null ||
        _selectedCity == null ||
        _selectedLocality == null ||
        _selectedFarmingType == null ||
        _selectedSeason == null) {
      setState(() {
        _error = 'Please select all options';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _showResults = true;
    });

    try {
      // Get weather information
      final weatherPrompt = '''
      For $_selectedLocality, $_selectedCity, $_selectedState, $_selectedCountry during $_selectedSeason season,
      please provide:
      1. Expected temperature range
      2. Weather conditions
      3. Rainfall predictions
      4. Any weather-related precautions for farming
      
      IMPORTANT: Use bold text (enclose with **) for:
      - Temperature ranges
      - Critical weather conditions
      - Important precautions
      - Key dates or timeframes
      
      Format the response in a clear, structured way.
      ''';

      final weatherResponse = await _aiService.getAIResponse(weatherPrompt);

      // Get crop recommendations
      final cropPrompt = '''
      For $_selectedFarmingType in $_selectedLocality, $_selectedCity, $_selectedState, $_selectedCountry during $_selectedSeason season,
      please recommend:
      1. Suitable crops to plant
      2. Planting schedule
      3. Expected yield
      4. Special considerations for the location and season
      
      IMPORTANT: Use bold text (enclose with **) for:
      - Crop names
      - Planting dates
      - Expected yields
      - Critical considerations
      
      Format the response in a clear, structured way.
      ''';

      final cropResponse = await _aiService.getAIResponse(cropPrompt);

      // Get fertilizer recommendations
      final fertilizerPrompt = '''
      For the recommended crops in $_selectedLocality, $_selectedCity, $_selectedState, $_selectedCountry during $_selectedSeason season,
      please provide:
      1. Required fertilizers and manure
      2. Application schedule
      3. Dosage recommendations
      4. Organic alternatives
      
      IMPORTANT: Use bold text (enclose with **) for:
      - Fertilizer names
      - Application dates
      - Dosage amounts
      - Critical warnings
      
      Format the response in a clear, structured way.
      ''';

      final fertilizerResponse = await _aiService.getAIResponse(fertilizerPrompt);

      setState(() {
        _weatherInfo = weatherResponse;
        _cropInfo = cropResponse;
        _fertilizerInfo = fertilizerResponse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to get agriculture information. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _localityController.dispose();
    super.dispose();
  }

  List<TextSpan> _parseMessageText(String text) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (Match match in boldPattern.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: const TextStyle(fontSize: 16),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(fontSize: 16),
      ));
    }

    return spans;
  }

  Widget _buildInfoCard(String title, String? content) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              if (content != null)
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 16,
                    ),
                    children: _parseMessageText(content),
                  ),
                )
              else
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool isLoading = false,
  }) {
    return AppTheme.dropdownStyle(
      label: label,
      value: value,
      items: items,
      onChanged: onChanged,
      isLoading: isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agriculture Assistant',
          style: TextStyle(color: AppTheme.primaryTextColor),
        ),
        backgroundColor: AppTheme.secondaryBackgroundColor,
        foregroundColor: AppTheme.primaryTextColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.primaryBackgroundColor,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_showResults) ...[
                _buildDropdownField(
                  label: 'Select Country',
                  value: _selectedCountry,
                  items: _countries,
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() {
                        _selectedCountry = value;
                        _selectedState = null;
                        _selectedCity = null;
                        _selectedLocality = null;
                        _selectedFarmingType = null;
                        _selectedSeason = null;
                        _farmingTypes = [];
                        _seasons = [];
                      });
                      await _fetchStatesForCountry(value);
                    }
                  },
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                if (_selectedCountry != null)
                  _buildDropdownField(
                    label: 'Select State',
                    value: _selectedState,
                    items: _locationData[_selectedCountry]!.keys.toList(),
                    onChanged: (value) async {
                      if (value != null) {
                        setState(() {
                          _selectedState = value;
                          _selectedCity = null;
                          _selectedLocality = null;
                          _selectedFarmingType = null;
                          _selectedSeason = null;
                          _farmingTypes = [];
                          _seasons = [];
                        });
                        await _fetchCitiesForState(_selectedCountry!, value);
                      }
                    },
                    isLoading: _isLoading,
                  ),
                const SizedBox(height: 16),
                if (_selectedState != null)
                  _buildDropdownField(
                    label: 'Select City',
                    value: _selectedCity,
                    items: _locationData[_selectedCountry!]![_selectedState!]!,
                    onChanged: (value) async {
                      if (value != null) {
                        setState(() {
                          _selectedCity = value;
                          _selectedLocality = null;
                          _selectedFarmingType = null;
                          _selectedSeason = null;
                          _farmingTypes = [];
                          _seasons = [];
                        });
                        await Future.wait([
                          _fetchFarmingTypes(),
                          _fetchSeasons(),
                        ]);
                      }
                    },
                    isLoading: _isLoading,
                  ),
                const SizedBox(height: 16),
                if (_selectedCity != null)
                  TextField(
                    controller: _localityController,
                    decoration: AppTheme.inputDecoration('Enter Locality'),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocality = value;
                      });
                    },
                  ),
                const SizedBox(height: 16),
                if (_selectedCity != null)
                  _buildDropdownField(
                    label: 'Select Farming Type',
                    value: _selectedFarmingType,
                    items: _farmingTypes,
                    onChanged: (value) {
                      setState(() {
                        _selectedFarmingType = value;
                      });
                    },
                    isLoading: _isLoading,
                  ),
                const SizedBox(height: 16),
                if (_selectedCity != null)
                  _buildDropdownField(
                    label: 'Select Season',
                    value: _selectedSeason,
                    items: _seasons,
                    onChanged: (value) {
                      setState(() {
                        _selectedSeason = value;
                      });
                    },
                    isLoading: _isLoading,
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _getAgricultureInfo,
                  style: AppTheme.primaryButtonStyle,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppTheme.lightTextColor)
                      : const Text('Get Recommendations'),
                ),
              ] else ...[
                _buildInfoCard('Weather Analysis', _weatherInfo),
                _buildInfoCard('Crop Recommendations', _cropInfo),
                _buildInfoCard('Fertilizer & Manure Guide', _fertilizerInfo),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showResults = false;
                      _weatherInfo = null;
                      _cropInfo = null;
                      _fertilizerInfo = null;
                      _selectedCountry = null;
                      _selectedState = null;
                      _selectedCity = null;
                      _selectedLocality = null;
                      _selectedFarmingType = null;
                      _selectedSeason = null;
                      _localityController.clear();
                      _locationData = {};
                      _farmingTypes = [];
                      _seasons = [];
                    });
                  },
                  style: AppTheme.primaryButtonStyle,
                  child: const Text('Start New Query'),
                ),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppTheme.errorColor),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 